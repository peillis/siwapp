defmodule Siwapp.InvoiceMailer do
  @moduledoc """
  This module manages building a invoice email ready to be delivered
  """
  alias Siwapp.Settings
  alias Siwapp.Templates
  alias Swoosh.Attachment

  import Swoosh.Email

  def build_invoice_email(invoice) do
    {subject, email_body} = Templates.subject_and_email_body(invoice)
    new()
    |> to({invoice.name, invoice.email})
    |> from({Settings.value(:company), Settings.value(:company_email)})
    |> subject(subject)
    |> html_body(email_body)
    |> add_attachment(invoice)
  end


  defp add_attachment(email, invoice) do
    pdf_name = "#{invoice.series.code}-#{Integer.to_string(invoice.number)}.pdf"
    str_template = Templates.print_str_template(invoice)
    {:ok, data} = ChromicPDF.print_to_pdf({:html, str_template})
    pdf_content = Base.decode64!(data)
    attachment = Attachment.new(
      {:data, pdf_content},
      filename: pdf_name,
      content_type: "application/pdf",
      type: :attachment
    )
    email
    |> attachment(attachment)
  end

end
