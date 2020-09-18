import React, { Component } from 'react';
import { Segment, Sidebar, Menu, Container } from 'semantic-ui-react'
import { HashRouter as Router, Route, Link } from "react-router-dom";


// import queryString from 'query-string';
// import { loadProjectFromUrl } from '../actions/actions.js';
import { connect } from 'react-redux'

class Page extends Component {
  // componentDidMount() {
  //   const parameters = queryString.parse(location.search)
  //   if (parameters.project != null) {
  //     this.props.dispatch(loadProjectFromUrl(parameters.project))
  //   }
  // }

  render() {
    return (
      <Router>
        <div className="fullHeight">
           Hello world!!!
        </div>
      </Router>
    );
  }
}

export default connect()(Page)
