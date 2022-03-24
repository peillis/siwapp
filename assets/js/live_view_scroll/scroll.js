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
}

let Hooks = {}
let checked = true

Hooks.InfiniteScroll = {
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
  reconnected() {
    this.pending = this.page()
    this.is_last_page = this.last_page()
  },  
  updated() { 
    this.pending = this.page()
    this.is_last_page = this.last_page()

    if(load_more() && this.is_last_page == "false"){
      this.pushEventTo("#infinite-scroll", "load-more", {})
    }
  }
}

export default Hooks