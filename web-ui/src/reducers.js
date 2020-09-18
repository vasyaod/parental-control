// @flow

import { combineReducers } from 'redux'
import { List } from 'immutable'


const initialState = {
  appState: {
    userStates: {

    }
  },
}

export function todoApp(state = initialState, action) {
  switch (action.type) {
    case 'STATE_LOADED':
      console.log("!!!!")
      return {...state,
        appState: action.values
      }

    default:
      return state
  }
}
