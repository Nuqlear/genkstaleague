'use strict';

var React = require('react');
var jQuery = require('jquery/dist/cdn/jquery-2.1.3.min');


var matches_url = '/api/matches/'


var MatchView = React.createClass({
    getInitialState: function() {
        return {match_id: undefined, data:{}};
    },
    loadDataFromServer: function() {
        jQuery.ajax({
            url: matches_url + this.props.match_id,
            dataType: 'json',
            success: function(data) {
                this.setState({data: data});
                console.log(JSON.stringify(data));
            }.bind(this),
            error: function(xhr, status, err) {
                console.error(status, err.toString());
            }.bind(this)
        });
    },
    componentDidMount: function() {
        this.loadDataFromServer();
    },
    render: function() {
        return (
            <div>
                <table>
                    <thead>
                        <tr>
                        <td>Match id</td>
                        <td>Duration</td>
                        <td>Date</td>
                        </tr>
                    </thead>
                    <tbody>
                        <td>1</td>
                        <td>2</td>
                        <td>3</td>
                    </tbody>
                </table>
                <h2> 
                </h2>
                <div>
                    <table>
                        <thead>
                            <tr >
                                <th>1</th>
                                <th>2</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>1
                                </td>
                                <td>2
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        );
    }
})

module.exports = MatchView
