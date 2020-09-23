import React, { Component } from 'react';
import { Segment, Sidebar, Menu, Container, Grid, Icon } from 'semantic-ui-react'

import { loadData, shareFacebook, shareTwitter } from '../actions.js'

import State from './State.jsx'
import Stats from './Stats.jsx'

import { connect } from 'react-redux'

class Page extends Component {

  constructor(props) {
    super(props);
    this.state = { activeItem: 'state' }
  }

  handleItemClick (e, { name }) {
    this.setState({ activeItem: name })
  }


  componentDidMount() {
    this.props.loadData()
  }

  render() {
    return (
        <div className="fullHeight">
          <Grid textAlign='center' style={{ height: '40em' }}>
            <Grid.Column style={{ width: '60em' }} textAlign='left'>

              <Segment basic>
                <Menu attached='top' tabular>
                  <Menu.Item name='state' active={this.state.activeItem === 'state'} onClick={this.handleItemClick.bind(this)}>
                    State
                  </Menu.Item>
                  <Menu.Item name='stats' active={this.state.activeItem === 'stats'} onClick={this.handleItemClick.bind(this)}>
                    Statistics
                  </Menu.Item>
                </Menu>
                {this.state.activeItem === 'state' && <State/>}
                {this.state.activeItem === 'stats' && <Stats/>}
              </Segment>
            </Grid.Column>
          </Grid>
          <Menu fixed='bottom' inverted>
              <Container text>
                <Menu.Item href='https://github.com/vasyaod/parental-control'>
                  <Icon name='github'/> Issues?
                </Menu.Item>
                <Menu.Item color='facebook' onClick={this.props.shareFacebook}>
                  <Icon name='facebook'/> Share on Facebook
                </Menu.Item>
                <Menu.Item color='twitter' onClick={this.props.shareTwitter}>
                  <Icon name='twitter'/> Share on Twitter
                </Menu.Item>
              </Container>
            </Menu>
        </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    
  };
};

export default connect(
  mapStateToProps,
  { loadData, shareFacebook, shareTwitter }
)(Page)

