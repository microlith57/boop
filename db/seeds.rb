# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create(
#     [{ name: 'Star Wars' }, { name: 'Lord of the Rings' }]
#   )
#   Character.create(name: 'Luke', movie: movies.first)

Admin.create(
  email: 'rohancrookbain@spotswoodcollege.school.nz',
  password: 'password'
)

rohan = Issuer.new(
  name: 'Rohan Crookbain',
  code: 'rohancrookbain',
  email: 'rohancrookbain@spotswoodcollege.school.nz',
  allowance: 1
)

rohan_b = Barcode.new owner: rohan
rohan_b.generate_code
rohan.save!
rohan_b.save!

cla = Issuer.new(
  name: 'Chris Lapworth',
  code: 'cla',
  email: 'cla@spotswoodcollege.school.nz',
  allowance: nil
)

cla_b = Barcode.new owner: cla
cla_b.generate_code
cla.save!
cla_b.save!

%w[W X Y Z].each do |l|
  1.upto 40 do |i|
    i = format '%<number>02d', number: i
    device = Device.new name: "CB-#{l}-#{i}"
    barcode = Barcode.new owner: device
    barcode.generate_code!
    device.save!
    barcode.save!
  end
end
