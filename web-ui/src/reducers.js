// @flow

import { combineReducers } from 'redux'
import { List } from 'immutable'


const initialState = {
  appState: {
    userStates: {

    }
  },
  stats: [],
}

export function todoApp(state = initialState, action) {
  switch (action.type) {
    case 'DATA_LOADED':
      console.log(action.stats)
      let s = List(action.stats)
        .groupBy(item =>item.user)
        .mapEntries(([key, values]) => {
          return [key, {
            user: key,
            actions: values.map(x => {return { 'date': x.date, 'count': (x.minutes / 60)}}).toArray()
          }]
        })
        .toList()
        .toArray()

      console.log(s)

      return {...state,
        appState: action.state,
        stats: s 
      }

    default:
      return state
  }
}
