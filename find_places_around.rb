# Ruby program to get from google places api (maps) all the types of places on radius.
# call ruby places.rb "LATITUDE, LONGITUDE" TYPE
# Example : ruby find_places_around.rb "-25.2823, -57.6350" atm  

require 'google_places'

if ARGV[0].nil?
    puts "put a latitude/longitude & type of business (optional)"
    exit
end


tipos = "accounting,airport,amusement_park,aquarium,art_gallery,atm,bakery,bank,bar,beauty_salon,bicycle_store,book_store,bowling_alley,bus_station,cafe,campground,car_dealer,car_rental,car_repair,car_wash,casino,cemetery,church,city_hall,clothing_store,convenience_store,courthouse,dentist,department_store,doctor,drugstore,electrician,electronics_store,embassy,fire_station,florist,funeral_home,furniture_store,gas_station,gym,hair_care,hardware_store,hindu_temple,home_goods_store,hospital,insurance_agency,jewelry_store,laundry,lawyer,library,light_rail_station,liquor_store,local_government_office,locksmith,lodging,meal_delivery,meal_takeaway,mosque,movie_rental,movie_theater,moving_company,museum,night_club,painter,park,parking,pet_store,pharmacy,physiotherapist,plumber,police,post_office,primary_school,real_estate_agency,restaurant,roofing_contractor,rv_park,school,secondary_school,shoe_store,shopping_mall,spa,stadium,storage,store,subway_station,supermarket,synagogue,taxi_stand,tourist_attraction,train_station,transit_station,travel_agency,university,veterinary_care,zoo"

API_KEY = ""
@client = GooglePlaces::Client.new(API_KEY)


latitud = ARGV[0].split(",")[0].strip.to_f
longitud = ARGV[0].split(",")[1].strip.to_f


if ARGV[1].nil?
    # No type was given
    lugares = @client.spots(latitud,longitud)
else
    if tipos.split(",").include? ARGV[1]
        lugares = @client.spots(latitud,longitud , :types => "#{ARGV[1]}", :radius => 3000 )
    else
        puts "#{ARGV[1]} is not a valid type"
    end
end

continua = true
final = []

while continua
    lugares.each do |recorre|
        datos = {}
        datos["name"] = recorre["name"]
        datos["status"] = recorre.json_result_object["business_status"]
        xlati = recorre.json_result_object["geometry"]["location"]["lat"]
        xlongi = recorre.json_result_object["geometry"]["location"]["lng"]
        datos["location"] = xlati.to_s+","+xlongi.to_s
        datos["place_id"] = recorre["place_id"]
        datos["vicinity"] = recorre.vicinity
        datos["types"] = recorre.types.join("|")
        datos["global_code"] = ""
        unless recorre.json_result_object["plus_code"].nil?
            datos["global_code"] = recorre.json_result_object["plus_code"]["global_code"]
        end
        final << datos
    end
    
    if lugares.last.nextpagetoken.nil?
        # Is this the last result page?
        continua = false
    else
        # Has more than 1 page
        sleep(3)
        lugares = @client.spots_by_pagetoken(lugares.last.nextpagetoken)
    end
end

archi = ARGV[0]
unless ARGV[1].nil?
    archi = archi+"-"+ARGV[1]
end
csv = CSV.open(archi,"w")

final.each do |h|
      csv << h.values
end

puts "Results saved on #{archi}"

# Sample result
# Heladería Y Cafetería Amandau,OPERATIONAL,"-25.1685259,-57.47537149999999",ChIJH_OXZ1qjXZQRHiMSVufnEUo,"RGJF+HVJ, General Elizardo Aquino, Limpio",cafe|store|food|point_of_interest|establishment,""
# La pequeña Italia,OPERATIONAL,"-25.167696,-57.4752136",ChIJo9xC4_ujXZQR8gdRk43Vk6w,"Mariscal estigarribia, Limpio",cafe|store|restaurant|food|point_of_interest|establishment,5864RGJF+WW
