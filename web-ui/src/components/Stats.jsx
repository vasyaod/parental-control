// @flow
import React, { Component, Fragment } from 'react';
import { Segment, Card, Image, Container, Header, Button} from 'semantic-ui-react'
//import Calendar from 'react-github-contribution-calendar';
import { connect } from 'react-redux'
import CalendarHeatmap from 'react-calendar-heatmap';
import ReactTooltip from 'react-tooltip';

import 'react-calendar-heatmap/dist/styles.css';

const style = {
  h1: {
    marginTop: '1em',
    marginBottom: '1em',
  },
}

class Stats extends Component {

  render() {
    return (
      <Container>
        <ReactTooltip />
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
                    <CalendarHeatmap  
                      values={value.actions}
                      tooltipDataAttrs={value => {
                        return {
                          'data-tip': `has count: ${value.count}`,
                        };
                      }}
                    />
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
