MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'istoria_staging'
  when :production  then MongoMapper.database = 'istoria_production'
  when :test        then MongoMapper.database = 'istoria_test'
end
