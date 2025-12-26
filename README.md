# 🚂 Signalbox

A system for operating model trains powered by DCC, written in Ruby.

## Installation

`gem install signalbox`

## Layout Setup

See `examples/layouts/`

## Running the server

`signalbox-server`

## Running the conductor TUI

`signalbox-conductor`

## DCC Client

Signalbox includes a DCC Client (`Signalbox::DCC::Client`) that can be used to
talk DCC to a command station over TCP. The canonical target for this client 
is a DCC-EX Command Station.

## Notes

This project is unrelated to and unaffiliated with Signalbox.io and related 
British Railway data projects.