function scrollAt() {
  let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
  let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  let clientHeight = document.documentElement.clientHeight

  return scrollTop / (scrollHeight - clientHeight) * 100
}
let Hooks = {}

Hooks.InfiniteScroll = {
  page() { return this.el.dataset.page },
  mounted() {
    this.pending = this.page()
    this.pass = true
    let timer
    window.addEventListener("scroll", e => {
      clearTimeout(timer)
      if (this.pending == this.page() && scrollAt() > 90 && this.pass) {
        this.pending = this.page() + 1
        this.pass = false
        this.pushEvent("load-more", {})
      }
      timer = setTimeout(() => {
        console.log("timeout")
        this.pass = true
      }, 100)
    })
  },
  reconnected() { this.pending = this.page() },
  updated() { this.pending = this.page() }
}
export default Hooks