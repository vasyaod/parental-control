
import * as config from './config.js'

export function loadState() {
  return async(dispatch) => {

    const res = await fetch(`${config.url}/state`)
    const data = await res.json()

    dispatch({
      type: 'STATE_LOADED',
      values: data
    })
  }
}