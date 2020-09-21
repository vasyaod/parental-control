// @flow
import React, { Component, Fragment } from 'react';
import { Segment, Card, Image, Container, Header, Button} from 'semantic-ui-react'
import Calendar from 'react-github-contribution-calendar';
import { connect } from 'react-redux'

const style = {
  h1: {
    marginTop: '1em',
    marginBottom: '1em',
  },
}

var values = {
  '2016-06-23': 1,
  '2016-06-26': 2,
  '2016-06-27': 3,
  '2016-06-28': 4,
  '2016-06-29': 4
}
var until = '2016-06-30';

class Stats extends Component {

  render() {
    return (
      <Container>
        <Header as='h1' content='Statistics' style={style.h1} textAlign='center' />
        { <Card.Group doubling itemsPerRow={1} stackable>
          { this.props.stats &&
            this.props.stats.map( value =>
              <Card 
                key={value.user}
              >
                <Card.Content>
                  <Card.Header>{value.user}</Card.Header>
                  <Card.Description>
                    <Calendar values={value.actions} />
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
    stats: state.stats
  };
};

export default connect(mapStateToProps)(Stats)
