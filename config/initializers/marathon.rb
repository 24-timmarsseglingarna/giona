MARATHON_THRESHOLDS = [
  { plaque: 'Brons',  series: 'Basic',           dist:    200 },
  { plaque: 'Silver', series: 'Basic',           dist:    500 },
  { plaque: 'Guld',   series: 'Basic',           dist:  1_000 },
  { plaque: 'Järn',   series: 'Basic',           dist:  2_000 },
  { plaque: 'Brons',  series: 'Emalj',           dist:  3_000 },
  { plaque: 'Silver', series: 'Emalj',           dist:  4_000 },
  { plaque: 'Guld',   series: 'Emalj',           dist:  5_000 },
  { plaque: 'Järn',   series: 'Emalj',           dist:  6_000 },
  { plaque: 'Brons',  series: 'Emalj hög serie', dist:  7_000 },
  { plaque: 'Silver', series: 'Emalj hög serie', dist:  8_000 },
  { plaque: 'Guld',   series: 'Emalj hög serie', dist:  9_000 },
  { plaque: 'Järn',   series: 'Emalj hög serie', dist: 10_000 },
].freeze

module MarathonThresholds
  # Highest threshold crossed at a given total distance
  def self.current_plaque(total_dist)
    MARATHON_THRESHOLDS.select { |t| total_dist >= t[:dist] }.last
  end

  # Thresholds newly crossed when going from prev_dist to total_dist
  def self.new_plaques(prev_dist, total_dist)
    MARATHON_THRESHOLDS.select { |t| t[:dist] > prev_dist && t[:dist] <= total_dist }
  end
end
