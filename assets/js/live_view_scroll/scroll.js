function scrollAt() {
    let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
    let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
    let clientHeight = document.documentElement.clientHeight
    
    return scrollTop / (scrollHeight - clientHeight) * 100
    }
export default scrollAt
