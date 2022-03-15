\c postgres
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'siwapp_demo'
AND pid <> pg_backend_pid();

\c siwapp_demo
ALTER TABLE taxes RENAME TO taxes_demo;
ALTER TABLE series RENAME TO series_demo;
ALTER TABLE items RENAME TO items_demo;
ALTER TABLE items_demo DROP COLUMN product_id;
ALTER TABLE items_demo DROP COLUMN deleted_at;
ALTER TABLE customers RENAME TO customers_demo;
ALTER TABLE payments RENAME TO payments_demo;
ALTER TABLE items_taxes RENAME TO items_taxes_demo;

CREATE FUNCTION change_column_with_function(table_name text, column_name text, t text, fun text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'ALTER TABLE ' || table_name || ' ALTER COLUMN ' || column_name || ' TYPE ' || t || ' USING ' || fun || '(' || column_name || ')';
END; $$;

CREATE FUNCTION to_cents(amount numeric)
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
  return amount*100;
END; $$;

CREATE FUNCTION period_type_conversion(period_type character varying(3))
RETURNS character varying(8)
LANGUAGE plpgsql
AS $$
DECLARE result character varying(8);
BEGIN
  case period_type
    when 'month' then result = 'Monthly';
    when 'day' then result = 'Daily';
    when 'year' then result = 'Yearly';
    else result='';
  end case;
  return result;
END; $$;

CREATE FUNCTION text_to_jsonb(meta_attribute text)
--this function will be used to change the meta_attributes
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE result jsonb;
BEGIN
    return NULL;
END; $$;

SELECT change_column_with_function('commons', 'net_amount', 'integer', 'to_cents');
SELECT change_column_with_function('commons', 'gross_amount', 'integer', 'to_cents');
SELECT change_column_with_function('commons', 'paid_amount', 'integer', 'to_cents');
SELECT change_column_with_function('commons', 'currency', 'character varying(3)', 'UPPER');
SELECT change_column_with_function('items_demo', 'unitary_cost', 'integer', 'to_cents');
SELECT change_column_with_function('payments_demo', 'amount', 'integer', 'to_cents');
SELECT change_column_with_function('commons', 'period_type', 'character varying(8)', 'period_type_conversion');
SELECT change_column_with_function('customers_demo', 'meta_attributes', 'jsonb', 'text_to_jsonb');
SELECT change_column_with_function('commons', 'meta_attributes', 'jsonb', 'text_to_jsonb');

DROP TABLE schema_migrations;
DROP TABLE settings;
DROP TABLE templates;
DROP TABLE users;
DROP TABLE webhook_logs;
DROP TABLE tags;
DROP TABLE taggings;
DROP TABLE ar_internal_metadata;
DROP TABLE products;

\c siwapp_dev
CREATE EXTENSION postgres_fdw;
CREATE SERVER localsrv FOREIGN DATA WRAPPER postgres_fdw OPTIONS(host 'localhost', dbname 'siwapp_demo', port '5432');
CREATE USER MAPPING FOR postgres SERVER localsrv OPTIONS(user 'postgres', password 'postgres');
IMPORT FOREIGN SCHEMA public FROM SERVER localsrv INTO public;

CREATE FUNCTION is_invoice(common_id integer)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE result boolean;
BEGIN
    if (SELECT type FROM commons WHERE id=common_id) = 'Invoice' then result = true;
    else result=false;
    end if;
    return result;
END; $$;

--taxes
-- value in demo was numeric, ours will round decimals
ALTER TABLE taxes_demo DROP COLUMN deleted_at;
INSERT INTO taxes SELECT * FROM taxes_demo;

--series
ALTER TABLE series_demo DROP COLUMN deleted_at;
INSERT INTO series SELECT * FROM series_demo;

-- I'm not inserting meta_attributes because they are all null in siwapp_demo and type text, so I don't know yet how to convert them to jsonb
--customers
ALTER TABLE customers_demo DROP COLUMN deleted_at;
ALTER TABLE customers_demo DROP COLUMN active;
INSERT INTO customers(id, name, hash_id, identification, email, contact_person, invoicing_address, shipping_address, meta_attributes, inserted_at, updated_at)
  SELECT *, NOW(), NOW() FROM customers_demo;

--recurring_invoices
CREATE FUNCTION build_items(id bigint)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE result jsonb;
BEGIN
    DROP TABLE IF EXISTS items_one_recurring_invoice;
    CREATE TABLE items_one_recurring_invoice(index serial, item jsonb);
    DROP SEQUENCE IF EXISTS index;
    CREATE SEQUENCE index START 1 OWNED BY items_one_recurring_invoice.index;
    INSERT INTO items_one_recurring_invoice(item)
      SELECT row_to_json(t) FROM
      (SELECT taxes, discount, quantity, description, unitary_cost
        FROM items_demo_extended WHERE common_id=id) t;
    WITH data(index, item) AS (SELECT * FROM items_one_recurring_invoice)
      SELECT json_object_agg(index-1,item) INTO result FROM data;
    return result;
END; $$;

CREATE TABLE items_taxes_names(item_id integer, taxes text[]);
INSERT INTO items_taxes_names
  SELECT items_demo.id, array_remove(array_agg(taxes.name), NULL) FROM items_demo
    LEFT JOIN items_taxes_demo ON items_demo.id=item_id
      LEFT JOIN taxes ON taxes.id=tax_id GROUP BY item_id, items_demo.id ORDER BY items_demo.id ASC;

CREATE TABLE items_demo_extended(common_id bigint, taxes text[], discount integer, quantity integer, description character varying(20000), unitary_cost integer);
INSERT INTO items_demo_extended
  SELECT common_id, taxes, discount, quantity, description, unitary_cost FROM items_demo
    LEFT JOIN items_taxes_names ON items_taxes_names.item_id=items_demo.id WHERE not is_invoice(common_id);

INSERT INTO recurring_invoices(series_id, customer_id, name, identification, email, invoicing_address, shipping_address, contact_person, terms, notes, net_amount, gross_amount, send_by_email, days_to_due, enabled, max_ocurrences, period, period_type, starting_date, finishing_date, inserted_at, updated_at, currency, items)
  SELECT series_id, customer_id, name, identification, email, invoicing_address, shipping_address, contact_person, terms, notes, net_amount, gross_amount, sent_by_email, days_to_due, enabled, max_occurrences, period, period_type, starting_date, finishing_date, created_at, updated_at, currency, build_items(id)
    FROM commons WHERE type='RecurringInvoice' ORDER BY id ASC;

--invoices
CREATE FUNCTION new_invoice_id(old_invoice_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE result integer;
BEGIN
    SELECT invoice_id INTO result FROM invoices_id_conversion WHERE common_id=old_invoice_id;
    return result;
END; $$;

INSERT INTO invoices(series_id, customer_id, name, identification, email, invoicing_address, shipping_address, contact_person, terms, notes, net_amount, gross_amount, paid_amount, draft, paid, sent_by_email, "number", recurring_invoice_id, issue_date, due_date, inserted_at, updated_at, deleted_at, failed, currency)
  SELECT series_id, customer_id, name, identification, email, invoicing_address, shipping_address, contact_person, terms, notes, net_amount, gross_amount, paid_amount, draft, paid, sent_by_email, "number", recurring_invoice_id, issue_date, due_date, created_at, updated_at, deleted_at, failed, currency
    FROM commons WHERE type='Invoice' ORDER BY id ASC;
CREATE TABLE invoices_id_conversion(invoice_id integer, common_id integer);
INSERT INTO invoices_id_conversion
  SELECT invoices.id, commons.id FROM invoices
    INNER JOIN commons ON invoices.name = commons.name AND invoices.identification = commons.identification
      ORDER BY invoices.id;

--items
-- discount and quantity in demo were numeric, ours will round decimals
INSERT INTO items(quantity, discount, description, unitary_cost, invoice_id)
  SELECT quantity, discount, description, unitary_cost, new_invoice_id(common_id)
    FROM items_demo WHERE is_invoice(common_id)=true;

-- payments
INSERT INTO payments("date", amount, notes, invoice_id, inserted_at, updated_at)
  SELECT "date", amount, notes, new_invoice_id(invoice_id), created_at, updated_at FROM payments_demo;

-- items_taxes
CREATE FUNCTION new_item_id(old_item_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE result integer;
BEGIN
    SELECT item_id INTO result FROM items_id_conversion WHERE item_demo_id=old_item_id;
    return result;
END; $$;
CREATE TABLE items_id_conversion(item_id integer, item_demo_id integer);
INSERT INTO items_id_conversion
  SELECT items.id, items_demo.id FROM items
    INNER JOIN items_demo ON items.description = items_demo.description
      ORDER BY items.id ASC;
INSERT INTO items_taxes SELECT new_item_id(item_id), tax_id FROM items_taxes_demo;

DROP FOREIGN TABLE taxes_demo;
DROP FOREIGN TABLE series_demo;
DROP FOREIGN TABLE customers_demo;
DROP FOREIGN TABLE commons;
DROP FOREIGN TABLE items_taxes_demo;
DROP FOREIGN TABLE items_demo;
DROP FOREIGN TABLE payments_demo;
DROP TABLE invoices_id_conversion;
DROP TABLE items_id_conversion;
DROP TABLE items_one_recurring_invoice;
DROP TABLE items_taxes_names;
DROP TABLE items_demo_extended;
