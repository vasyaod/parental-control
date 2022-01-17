
export function loadData() {
  return async(dispatch) => {

    const res = await fetch(`/state`)
    const state = await res.json()
    const res1 = await fetch(`/stats`)
    const stats = await res1.json()

    dispatch({
      type: 'DATA_LOADED',
      state: state,
      stats: stats
    })
  }
}

export function shareFacebook() {
  return async (dispatch) => {
    const title = "Parental control for *nix OS"
    const url = "https://vasyaod.github.io/parental-control";
    const facebookShareUrl = `https://www.facebook.com/sharer/sharer.php?u=${encodeURI(url)}&t=${title}`
    window.open(facebookShareUrl, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=300,width=600')
  }
}
  
export function shareTwitter() {
  return async (dispatch) => {
    const text = "Parental control for *nix OS"
    const twitterHandle = "parental-control"
    const url = "https://vasyaod.github.io/parental-control";
    const twitterShareUrl = `https://twitter.com/share?url=${encodeURI(url)}&via=${twitterHandle}&text=${text}`
    window.open(twitterShareUrl, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=300,width=600')
  }
}