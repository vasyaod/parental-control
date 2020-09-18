// @flow
import React from 'react'
import ReactDOM from 'react-dom';
import thunkMiddleware from 'redux-thunk'
import { Provider } from 'react-redux'
import { createStore, applyMiddleware } from 'redux'

import {todoApp} from './reducers.js';
import Page from './components/Page.jsx'

const store = createStore(todoApp, applyMiddleware(thunkMiddleware))

const render = () =>
  ReactDOM.render(
    <Provider store={store}>
      <Page/>
    </Provider>,
    document.getElementById('app')
  )

render()
store.subscribe(render)