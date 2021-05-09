class CreateAirplane < ActiveRecord::Migration[5.2]

  require_relative '../../ftwbot.rb'
  def change
    create_table :planes do |t|
      t.string :name
    end
    add_reference :flights, :plane, foreign_key: true

    Flight.all.each do |flight|
      case flight.aircraft
      when 'A320', 'M.A320', 'B.A320', 'M.A.320', 'a320'
        flight.plane_id = Plane.find_or_create_by(name: 'A320').id
        flight.save
      when 'DC6'
        flight.plane_id = Plane.find_or_create_by(name: 'DC6').id
        flight.save
      when 'B757', 'b757', 'b752', 'B737-800', 'B753', '753', '757', 'M.757', 'L.757', 'L757'
        flight.plane_id = Plane.find_or_create_by(name: 'B757').id
        flight.save
      when 'Citation2'
        flight.plane_id = Plane.find_or_create_by(name: 'Citation2').id
        flight.save
      when 'B738', 'B378', '737', 'b737', 'B737'
        flight.plane_id = Plane.find_or_create_by(name: 'B738').id
        flight.save
      when 'E195', 'L195', 'L.195', 'L-E195', 'EMB195', 'L.E195'
        flight.plane_id = Plane.find_or_create_by(name: 'E195').id
        flight.save
      when 'E170'
        flight.plane_id = Plane.find_or_create_by(name: 'E170').id
        flight.save
      when 'B748'
        flight.plane_id = Plane.find_or_create_by(name: 'B748').id
        flight.save
      when 'S340'
        flight.plane_id = Plane.find_or_create_by(name: 'S340').id
        flight.save
      when 'DC3'
        flight.plane_id = Plane.find_or_create_by(name: 'DC3').id
        flight.save
      when 'TMB', 'TMB850'
        flight.plane_id = Plane.find_or_create_by(name: 'TMB850').id
        flight.save
      when 'MD82', 'MD-82'
        flight.plane_id = Plane.find_or_create_by(name: 'MD82').id
        flight.save
      when 'MD80'
        flight.plane_id = Plane.find_or_create_by(name: 'MD80').id
        flight.save
      else
        flight.plane_id = Plane.find_or_create_by(name: flight.aircraft).id
        flight.save
      end
    end

    remove_column :flights, :airplane

  end
end
