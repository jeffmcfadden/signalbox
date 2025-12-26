layout name: "main" do
  dcc do
    host "192.168.0.22"
    port 2560
  end

  cab do
    name "Santa Fe 3751"
    address 2
    acceleration 5
  end

  sector do
    id 1
    name "'Round the Mountain"
  end

  sector do
    id 2
    name "Hill Climb"
  end

  sector do
    id 3
    name "Hill Descent"
  end

  proximity_sensor do
    sector_id 1
    id 'end_of_hill'
  end

  proximity_sensor do
    sector_id 2
    id 'beginning_of_hill'
  end

  proximity_sensor do
    sector_id 3
    id 'crest_of_hill'
  end
end