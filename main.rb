require "google_drive"
require_relative 'kod'

# session = GoogleDrive::Session.from_config("config.json")

t = Tabela.new("1iUBRToTv8yZrpWUP_r8BNPiNUBRQifFEOO5okK-d59Y", 0)

t.print

t.row(2)
t.each {|row| p row} #ispisuje sve redove

p t["PrvaKolona"][1] = 7
p t["PrvaKolona"].to_s

p t.drugaKolona.to_s

suma=t.prvaKolona.sum
p suma

average=t.prvaKolona.avg
p average

p t.index.rn11322

p t.prvaKolona.map { |cell| cell+=10 }
p t.trecaKolona.select { |cell| cell.to_i < 5 }
p t.trecaKolona.reduce(2) { |suma, n| suma + n }
