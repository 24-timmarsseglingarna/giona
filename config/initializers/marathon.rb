MARATHON_THRESHOLDS = [
  { plaque: 'Brons',  series: '',                dist:    200 },
  { plaque: 'Silver', series: '',                dist:    500 },
  { plaque: 'Guld',   series: '',                dist:  1_000 },
  { plaque: 'Järn',   series: '',                dist:  2_000 },
  { plaque: 'Brons',  series: 'Emalj',           dist:  3_000 },
  { plaque: 'Silver', series: 'Emalj',           dist:  4_000 },
  { plaque: 'Guld',   series: 'Emalj',           dist:  5_000 },
  { plaque: 'Järn',   series: 'Emalj',           dist:  6_000 },
  { plaque: 'Brons',  series: 'Emalj hög serie', dist:  7_000 },
  { plaque: 'Silver', series: 'Emalj hög serie', dist:  8_000 },
  { plaque: 'Guld',   series: 'Emalj hög serie', dist:  9_000 },
  { plaque: 'Järn',   series: 'Emalj hög serie', dist: 10_000 },
].freeze

# A sailor is flagged as "near a plaque" when this close (in nautical miles)
# to the next threshold.
NEAR_PLAQUE_DIST = 75

module MarathonThresholds
  # Highest threshold crossed at a given total distance
  def self.current_plaque(total_dist)
    MARATHON_THRESHOLDS.select { |t| total_dist >= t[:dist] }.last
  end

  # Thresholds newly crossed when going from prev_dist to total_dist
  def self.new_plaques(prev_dist, total_dist)
    MARATHON_THRESHOLDS.select { |t| t[:dist] > prev_dist && t[:dist] <= total_dist }
  end

  # The next threshold above total_dist, or nil if all have been crossed.
  def self.next_plaque(total_dist)
    MARATHON_THRESHOLDS.find { |t| t[:dist] > total_dist }
  end

  # Distance remaining to the next threshold above total_dist, or nil if all
  # thresholds have already been crossed.
  def self.dist_to_next_plaque(total_dist)
    nxt = next_plaque(total_dist)
    nxt && (nxt[:dist] - total_dist)
  end
end
