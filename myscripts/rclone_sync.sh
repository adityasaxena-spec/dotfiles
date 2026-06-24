#!/bin/bash

notify-send "sync started!"

rclone sync /home/aditya/notes aditya@gg:notes\'

notify-send "sync completed!"
