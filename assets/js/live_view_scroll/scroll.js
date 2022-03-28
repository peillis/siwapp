function type_of_root(el) {
  id = el.id

  if (id == "infinite-scroll") {
    root = null
  } else {
    root = document.querySelector('#customers_list_ancestor')
  }

  return root
}

let Hooks = {}

Hooks.InfiniteScroll = {
  page() { return this.el.dataset.page },
  no_more_queries() { return this.el.dataset.no_more_queries },
  loadMore(entries, no_queries) {
    const target = entries[0];
    
    if (target.isIntersecting && this.pending == this.page() && no_queries == 0) {
      this.pending = this.page() + 1;
      this.pushEventTo(target.target, "load-more", {});
    }
  },
  mounted() {
    this.pending = this.page();
    this.no_queries = this.no_more_queries();
    this.observer = new IntersectionObserver(
      (entries) => this.loadMore(entries, this.no_queries),
      {
        root: type_of_root(this.el), // window by default
        rootMargin: "0px",
        threshold: 1.0,
      }
    );
    this.observer.observe(this.el);
  },
  beforeDestroy() {this.observer.unobserve(this.el);},
  reconnected() {
    this.pending = this.page()
    this.no_queries = this.no_more_queries()
  },
  updated() {
    this.pending = this.page()
    this.no_queries = this.no_more_queries()
    this.observer = new IntersectionObserver(
      (entries) => this.loadMore(entries, this.no_queries),
      {
        root: type_of_root(this.el), // window by default
        rootMargin: "0px",
        threshold: 1.0,
      }
    );
    this.observer.observe(this.el);
  }
}

export default Hooks