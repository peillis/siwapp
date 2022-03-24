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
  if (window.innerWidth == document.documentElement.clientWidth){
    return true
  }
  else {
    return false
  }
}

let Hooks = {}
let checked = true

Hooks.InfiniteScroll = {
  page() { return this.el.dataset.page },
  no_more_queries() { return this.el.dataset.no_more_queries },
  mounted() {
    this.pending = this.page()
    let element  = type_of_element(this.el)
    this.no_queries = this.no_more_queries()

    if (load_more() && checked && this.no_queries == 0) {
      checked = false
      this.pushEventTo("#infinite-scroll", "load-more", {})
    }

    element.addEventListener("scroll", () => {
      if (this.pending == this.page() && scrollAt(element) > 90 && this.no_queries == 0) {
        this.pending = this.page() + 1
        this.pushEventTo("#" + this.el.id, "load-more", {})
      }
    })
  },
  reconnected() {
    this.pending = this.page()
    this.no_queries = this.no_more_queries()
  },  
  updated() { 
    this.pending = this.page()
    this.no_queries = this.no_more_queries()

    if(load_more() && this.no_queries == 0){
      this.pushEventTo("#infinite-scroll", "load-more", {})
    }
  }
}

export default Hooks