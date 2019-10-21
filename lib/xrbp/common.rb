require 'time'

module XRBP
  # Genesis Ledger:
  # https://wiki.ripple.com/Genesis_ledger
  #
  # Created on 2013-01-01
  # https://data.ripple.com/v2/ledgers/32570
  GENESIS_TIME = DateTime.new(2013, 1, 1, 0, 0, 0)

  # Convert XRP Ledger time to local time
  def self.from_xrp_time(xrp_time)
    return nil if xrp_time.nil?
    Time.at(xrp_time + 946684800)
  end

  # Convert local time to XRP Time
  def self.to_xrp_time(local_time)
    return nil if local_time.nil?
    local_time.to_i + 946684800
  end
end # module XRBP
