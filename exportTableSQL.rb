require 'sqlite3'
require 'csv'

def getAll(db,tbl,what,param,value,hash)
	db.results_as_hash = true if hash
	table=arrayCase(tbl)
	return if table==nil
	if param==nil
		if what==nil
			return db.execute "SELECT * FROM '#{table}'"	
		else
			return db.execute "SELECT "+what+" FROM '#{table}'"
		end
	else
		val=prepareStr(value)
		if what==nil
			return db.execute "SELECT * FROM '#{table}' WHERE "+param+"="+val	
		else
			return db.execute "SELECT "+what+" FROM '#{table}' WHERE "+param+"="+val
		end
	end
end

def getColumnNames(db,tbl)
	table=arrayCase(tbl)
	return if table==nil
	result=db.prepare "SELECT * FROM '#{table}'"
	return result.columns
end

def prepareStr(input)
	res=""
	if input.is_a? String 
		res='"'+input.gsub('"',"%22")+'"'
	else
		input.each{ |s| 
			if s.is_a? String
				str='"'+s.gsub("\n","").gsub('"',"%22")+'"'.force_encoding("iso-8859-1")
			else
				str=s.to_s.force_encoding("iso-8859-1")
			end
			if res!=""
				res=res+","+str.force_encoding("iso-8859-1")
			else
				res=str
			end}
	end
	return res
end

def arrayCase(tbl)
	if tbl.kind_of?(Hash)	
		return tbl.keys[0] 
	else		#beaconsURL
		return tbl
	end
end

dbname=ARGV[0]
abort "No input DB" if ARGV[0]==nil
abort "No input table" if ARGV[1]==nil
table=ARGV[1]
db=SQLite3::Database.open dbname
results=getAll(db,table,nil,nil,nil,false)
columnNames=getColumnNames(db,table)
CSV.open(dbname.rpartition("/")[0]+"/"+table+".csv","w") do |csv|
  csv << columnNames 
  results.each { |row| csv << row }
end
