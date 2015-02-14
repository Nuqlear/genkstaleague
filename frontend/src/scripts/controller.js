'use strict';

var React = require('react');
var Routie = require('routie/dist/routie.min');
var MatchView = require('./views/match.js');

// CSS
require('../styles/normalize.css');
require('../styles/main.css');


var render_place = document.getElementById('content');


routie({
    '/': function() {
        React.render(
            <div>
                <h1>Gleague index view</h1>
                <a href="/#/matches/1220039146">match view</a>
            </div>,
            render_place
        );
    },
    '/matches/:match_id': function(match_id) {
        React.render(<MatchView match_id={match_id}/>, render_place);
    },
    '*': function() {
        routie('/');
    }
});