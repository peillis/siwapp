<<<<<<< HEAD
function type_of_root(el) {
  id = el.id

  if (id == "infinite-scroll") {
    root = null
  } else {
    root = document.querySelector('#customers_list_ancestor')
  }

  return root
=======
function scrollAt(el) {
  if(el == window) {
    el = document.documentElement
  }

  let scrollTop = el.scrollTop
  let scrollHeight = el.scrollHeight
  let clientHeight = el.clientHeight

  return scrollTop / (scrollHeight - clientHeight) * 100
}

function type_of_element(el) {
  id = el.id

  if (id == "infinite-scroll") {
    el = window
  }

  return el
}

function load_more() {
  if (window.innerWidth == document.documentElement.scrollWidth){
    return true
  }
  else {
    return false
  }
>>>>>>> 2103c95 (not making unnecessary queries for scroll events and load-more if it does not appear the scroll-bar)
}

let Hooks = {}
let checked = true

Hooks.InfiniteScroll = {
<<<<<<< HEAD
  page() {return this.el.dataset.page},
  no_more_queries() { return this.el.dataset.no_more_queries },
  loadMore(entries) {
    const target = entries[0];

    if (target.isIntersecting && this.pending == this.page() && this.no_more_queries() == 0) {
      this.pending = this.pending + 1
      this.pushEventTo(target.target, "load-more", {});
    }
  },
  mounted() {
    this.pending = this.page()
    this.observer = new IntersectionObserver(
      (entries) => this.loadMore(entries),
      {
        root: type_of_root(this.el), // window by default
        rootMargin: "0px",
        threshold: 1.0,
      }
    );
    this.observer.observe(this.el);
  },
  beforeDestroy() {this.observer.unobserve(this.el);},
  updated() {
    this.pending = this.page()
    this.observer = new IntersectionObserver(
      (entries) => this.loadMore(entries),
      {
        root: type_of_root(this.el), // window by default
        rootMargin: "0px",
        threshold: 1.0,
      }
    );
    this.observer.observe(this.el);
  }
=======
  page() { return this.el.dataset.page },
  last_page() { return this.el.dataset.last_page },
  mounted() {
    this.pending = this.page()
    let element  = type_of_element(this.el)
    this.is_last_page = this.last_page()

    if (load_more() && checked && this.is_last_page == "false") {
      checked = false
      this.pushEventTo("#infinite-scroll", "load-more", {})
    }

    element.addEventListener("scroll", () => {
      if (this.pending == this.page() && scrollAt(element) > 90 && this.is_last_page == "false") {
        this.pending = this.page() + 1
        this.pushEventTo("#" + this.el.id, "load-more", {})
      }
    })
  },
  reconnected() { this.pending = this.page()
                  this.is_last_page = this.last_page()
                },
  updated() { this.pending = this.page()
              this.is_last_page = this.last_page()              
              if(load_more() && this.is_last_page == "false"){                
                this.pushEventTo("#infinite-scroll", "load-more", {})
              }
            }
>>>>>>> 2103c95 (not making unnecessary queries for scroll events and load-more if it does not appear the scroll-bar)
}

export default Hooks