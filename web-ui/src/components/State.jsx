// @flow
import React, { Component, Fragment } from 'react';
import { Segment, Card, Image, Container, Header, Button} from 'semantic-ui-react'
import { connect } from 'react-redux'

const style = {
  h1: {
    marginTop: '1em',
    marginBottom: '1em',
  },
}

function formatTime(hours) {
  let h = Math.floor(hours / 60)
  let m = Math.floor((hours - h*60))
  return `${h}h ${m}m`
}

class State extends Component {

  render() {
    return (
      <Container>
        <Header as='h1' content='Consumed time for today' style={style.h1} textAlign='center' />
        { <Card.Group doubling itemsPerRow={1} stackable>
          { this.props.userStates &&
            Object.entries(this.props.userStates).map( ([key, value]) =>
              <Card 
                key={key}
              >
                <Card.Content>
                  <Card.Header>{key}</Card.Header>
                  <Card.Description>
                    <Header as='h1' style={style.h1}>Used {formatTime(value.minuteCount)}</Header>
                  </Card.Description>
                </Card.Content>
              </Card>
            )
          }
        </Card.Group>}
      </Container>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    userStates: state.appState.userStates
  };
};

export default connect(mapStateToProps)(State)
