# Programa que cambia la foto de perfil de @tu_usuario_de_twitter por una al azar 
# Tienes que tener las fotos que quieres que publique en una carpeta denominada /images
# Tambien crea otra carpeta /posteadas para que una vez que postee mueva las imagenes alli asi no las vuelve a postear
# Antes que nada tienes que crearte una app en Twitter con tu perfil en https://developer.twitter.com/en/portal/ , alli te generara todos los parametros requeridos abajo.

require "csv"
require "byebug"
require "open-uri"
require "twitter"
require 'fileutils'

# Variables que las vas a sacar de https://developer.twitter.com/en/portal/
CONSUMER_KEY = ""
CONSUMER_SECRET = ""
ACCESS_TOKEN = ""
ACCESS_TOKEN_SECRET = ""

# Aqui pones tu usuario nombre de usuario y si completas TWITTERPOST va a postear bajo ese hilo las fotos que vaya subiendo a tu perfil.
TWITTERUSER = "" 
TWITTERPOST = "" #If empty won't post the image, only change the profile pic.

archivos = Dir["./images/*.jpg"]
if archivos.count == 0
    exit
end
azar = archivos.sample


client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end
actualiza = client.update_profile_image(open(azar))
unless TWITTERPOST==""
    postea1 = client.update_with_media("",azar, attachment_url: "https://twitter.com/#{TWITTERUSER}/status/#{TWITTERPOST}" )      
end
xarchivo = azar.split("/").last
FileUtils.mv(azar, "./posteadas/#{xarchivo}")
