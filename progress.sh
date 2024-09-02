#!/bin/bash

total_steps=50
progress=0
steps=50

echo -n "[--------------------] 0%"

while [ $progress -le $total_steps ]; do
  # Calculate the number of '#' to display
  let filled_slots=progress*$steps/total_steps

  # Create the progress bar string
  bar=""
  for ((i=0; i<filled_slots; i++)); do
    bar="${bar}#"
  done

  for ((i=filled_slots; i<$steps; i++)); do
    bar="${bar}-"
  done

  let percentage=progress*100/total_steps
  echo -ne "\r[${bar}] ${percentage}%"
  sleep 0.1

  let progress++
done
echo
