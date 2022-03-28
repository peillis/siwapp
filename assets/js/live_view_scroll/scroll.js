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


function has_Overflow(el)
{
   var curOverflow = el.style.overflow;

   if ( !curOverflow || curOverflow === "visible" )
      el.style.overflow = "hidden";

   var isOverflowing = el.clientWidth < el.scrollWidth 
      || el.clientHeight < el.scrollHeight;

   el.style.overflow = curOverflow;   
   
   return isOverflowing;
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

    if (!has_Overflow(document.documentElement) && checked && this.no_queries == 0) {
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

    if(!has_Overflow(document.documentElement) && this.no_queries == 0){
      this.pushEventTo("#infinite-scroll", "load-more", {})
    }
  }
}

export default Hooks