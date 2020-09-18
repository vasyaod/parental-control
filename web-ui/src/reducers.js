// @flow

import { combineReducers } from 'redux'
import { List } from 'immutable'


const initialState = {
  appState: [],
}

export function todoApp(state = initialState, action) {
  switch (action.type) {
    case 'OBJECTS_CHANGED':
      return {...state,
        objects: action.values
      }

    default:
      return state
  }
}
