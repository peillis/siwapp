function scrollAt(el) {
  let scrollTop = el.scrollTop
  let scrollHeight = el.scrollHeight
  let clientHeight = el.clientHeight

  return scrollTop / (scrollHeight - clientHeight) * 100
}

function type_of_element(element) {
  if (element == window) {
    element_array = [document.documentElement, "#infinite-scroll"]
  } else {
    element_array = [element, "#customers_list"]
  }
  return element_array
}
let Hooks = {}

Hooks.InfiniteScroll = {
  page() { return this.el.dataset.page },
  mounted() {
    this.pending = this.page()
    this.pass = true
    let timer
    let array = [this.el, window];
    array.forEach(element => {
      let element_array  = type_of_element(element)
      element.addEventListener("scroll", () => {
        clearTimeout(timer)
        if (this.pending == this.page() && scrollAt(element_array[0]) > 90 && this.pass) {
          this.pending = this.page() + 1
          this.pass = false
          this.pushEventTo(element_array[1], "load-more", {})
        }
        timer = setTimeout(() => {
          console.log("timeout")
          this.pass = true
        }, 100)
      })
    })
  },
  reconnected() { this.pending = this.page() },
  updated() { this.pending = this.page() }
}
export default Hooks