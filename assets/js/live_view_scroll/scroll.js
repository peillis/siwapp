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
    let deadtime = 100;
    let lastCall = 0;
    window.addEventListener("scroll", e => {
      const now = (new Date).getTime();
      if (this.pending == this.page() && scrollAt() > 90) {
        if (now - lastCall > deadtime) {
          lastCall = now;
          this.pending = this.page() + 1
          this.pushEvent("load-more", {})
        } else
          lastCall = now;
      }
    })
  },
  reconnected() { this.pending = this.page() },
  updated() { this.pending = this.page() }
}

export default Hooks