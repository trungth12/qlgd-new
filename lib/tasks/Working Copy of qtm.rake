#encoding: utf-8
require 'hpu'
namespace :qtm do    
  #10
  task reindex:  :environment do
    Tenant.all.each do |tenant|    
      Octopus.using(tenant.database) do 
        SinhVien.reindex
        LopMonHoc.reindex    
        LichTrinhGiangDay.reindex
        Sunspot.commit
      end
    end
  end
	#0 prepare tenant
  task create_tenant: :environment do 
    tenant = Tenant.last
    Octopus.using(tenant.database) do             
        Tenant.where(hoc_ky: tenant.hoc_ky, nam_hoc: tenant.nam_hoc, name: tenant.name).first_or_create!
    end    
  end
	#1 Load tuan
#Date.new(2016, 1, 11) chinh sua ngay bat dau cua hoc ky
#stt neu ky 1 t+1, neu ky 2 =t+23
  task load_tuan: :environment do 
    #Apartment::Database.switch('public')
    tenant = Tenant.last
    Octopus.using(tenant.database) do 
      Tuan.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('tuans') 
      d = Date.new(2016, 1, 11)
      (0..20).each do |t|
          Tuan.where(:stt => t+23, :tu_ngay => d + t.weeks, :den_ngay => d + t.weeks + 6.day).first_or_create!
      end 
    end
  end
  #12: update phong
  task load_phong: :environment do 
    tenant = Tenant.last
    Octopus.using(tenant.database) do 
      @client = Savon.client(wsdl: "http://10.1.0.236:8088/HPUWebService.asmx?wsdl")
      response = @client.call(:phong_hoc)
      res_hash = response.body.to_hash
      ls = res_hash[:phong_hoc_response][:phong_hoc_result][:diffgram][:document_element]
      ls = ls[:phong_hoc]    
      ls.each do |l|        
        Phong.create(ma_phong: l[:ma_phong_hoc].strip, toa_nha: l[:ma_toa_nha].strip, tang: l[:chi_so_tang].to_i, suc_chua_toi_da: l[:so_ban].to_i * l[:he_so_hoc].to_i, loai: l[:kieu_phong])
      end
    end
  end

  #13: Danh muc mon hoc
  task load_mon_hoc: :environment do 
    tenant = Tenant.last
    Octopus.using(tenant.database) do 
      @client = Savon.client(wsdl: "http://10.1.0.236:8088/HPUWebService.asmx?wsdl")
      response = @client.call(:danh_muc_mon_hoc)
      res_hash = response.body.to_hash
      ls = res_hash[:danh_muc_mon_hoc_response][:danh_muc_mon_hoc_result][:diffgram][:document_element]
      ls = ls[:danh_muc_mon_hoc]    
      ls.each do |l|        
        MonHoc.where(ma_mon_hoc: l[:ma_mon_hoc].strip.upcase, ten_mon_hoc: l[:ten_mon_hoc].strip).first_or_create!
      end
    end
  end
  #2 load giang vien  and sinh vien
  task :load_sinh_vien => :environment do
    tenant = Tenant.last
    Octopus.using(tenant.database) do 
    #SinhVien.delete_all
    #ActiveRecord::Base.connection.reset_pk_sequence!('sinh_viens')
    # attr_accessible :gioi_tinh, :ho_dem, :lop_hc, :ma_he_dao_tao, :ma_khoa_hoc, :ma_nganh, :ma_sinh_vien, :ngay_sinh, :ten, :trang_thai, :ten_nganh

      @client = Savon.client(wsdl: "http://10.1.0.236:8088/HPUWebService.asmx?wsdl")
      response = @client.call(:sinh_vien_dang_hoc)
      res_hash = response.body.to_hash
      ls = res_hash[:sinh_vien_dang_hoc_response][:sinh_vien_dang_hoc_result][:diffgram][:document_element]
      ls = ls[:sinh_vien_dang_hoc]
      puts "loading ... sinh viens"
      ls.each do |l|
        sv = SinhVien.where(code: (l[:ma_sinh_vien].strip.upcase if l[:ma_sinh_vien]) ).first
        unless sv
          tmp = titleize(l[:hodem].strip.downcase).split(" ")
          ho = tmp[0]
          dem = tmp[1..-1].join(" ")
          ns = l[:ngay_sinh].to_time if l[:ngay_sinh]
		  ns = ns + 1
          ten =  titleize(l[:ten].strip.downcase) if l[:ten] and l[:ten].is_a?(String)
          #ep = convert(ten) + convert(dem)+ convert(ho)+ ns.strftime("%d%m%Y")
		  ep = convert(ten) + convert(dem)+ convert(ho)+ ns.strftime("%Y%m%d")
          SinhVien.create!(
            gioi_tinh: (l[:gioi_tinh] ? 1 : 0),
            ho: ho,
            dem: dem,
            ma_lop_hanh_chinh: (l[:lop].strip.upcase if l[:lop] and l[:lop].is_a?(String) ) ,
            he: ( titleize(l[:ten_he_dao_tao].strip.downcase) if l[:ten_he_dao_tao] and l[:ten_he_dao_tao].is_a?(String) ),
            khoa: ( titleize(l[:ten_khoa_hoc].strip.downcase) if l[:ten_khoa_hoc] and l[:ten_khoa_hoc].is_a?(String) ) ,
            code: (l[:ma_sinh_vien].strip.upcase if l[:ma_sinh_vien]),
            ngay_sinh: ns,
            ten: ten,
            nganh: ( titleize(l[:ten_nganh].strip.downcase) if l[:ten_nganh] and l[:ten_nganh].is_a?(String) ),
            tin_chi: ( l[:dao_tao_theo_tin_chi] ? true : false ),
            encoded_position: ep
          )
        end
        if sv
          if sv.ma_lop_hanh_chinh != l[:lop].strip.upcase
            sv.update_attributes(ma_lop_hanh_chinh: l[:lop].strip.upcase, he: ( titleize(l[:ten_he_dao_tao].strip.downcase) if l[:ten_he_dao_tao] and l[:ten_he_dao_tao].is_a?(String) ),
            khoa: ( titleize(l[:ten_khoa_hoc].strip.downcase) if l[:ten_khoa_hoc] and l[:ten_khoa_hoc].is_a?(String) ) , nganh: ( titleize(l[:ten_nganh].strip.downcase) if l[:ten_nganh] and l[:ten_nganh].is_a?(String) ))
          end
        end
      end
    end
  end 
  task load_giang_vien: :environment do
    tenant = Tenant.last
    Octopus.using(tenant.database) do 
    #GiangVien.delete_all
    #ActiveRecord::Base.connection.reset_pk_sequence!('giang_viens') 
      @client = Savon.client(wsdl: "http://10.1.0.236:8088/HPUWebService.asmx?wsdl")
      response = @client.call(:danh_sach_can_bo_giang_vien)         
      res_hash = response.body.to_hash                
      ls = res_hash[:danh_sach_can_bo_giang_vien_response][:danh_sach_can_bo_giang_vien_result][:diffgram][:document_element]
      ls = ls[:danh_sach_can_bo_giang_vien]
      puts "loading... giang_vien"
      ls.each_with_index do |l,i|     
        tmp = titleize(l[:ho_dem].strip.downcase).split(" ")          
        ho = tmp[0]
        dem = tmp[1..-1].join(" ")
        ten = l[:ten].strip
        ep = convert(ten) + convert(dem)+ convert(ho)
        gv = GiangVien.where(:code => l[:ma_giao_vien].strip.upcase).first_or_create!
        gv.update_attributes(:ho => ho, :dem => dem, :ten => ten, ten_khoa: l[:ten_khoa].strip, encoded_position: ep)
        khoa = Khoa.where(ten_khoa: l[:ten_khoa].strip).first_or_create!
        if l[:quyen_duyet] == true
          khoa.giang_vien = gv
          khoa.save!
        end
      end
    end
  end
  
  #3
  task load_lop_mon_hoc: :environment do
    tenant = Tenant.last
    Octopus.using(tenant.database) do 
		#LopMonHoc.delete_all
		#ActiveRecord::Base.connection.reset_pk_sequence!('lop_mon_hocs') 
		@client = Savon.client(wsdl: "http://10.1.0.236:8088/HPUWebService.asmx?wsdl")
		response = @client.call(:tkb_theo_giai_doan)         
		res_hash = response.body.to_hash                
		ls = res_hash[:tkb_theo_giai_doan_response][:tkb_theo_giai_doan_result][:diffgram][:document_element]
		ls = ls[:tkb_theo_giai_doan]
		puts "loading... lop mon hoc"
		ls.each_with_index do |l,i|       
			#Add lop_mon_hoc
			lop = LopMonHoc.where(:ma_lop => l[:ma_lop].strip.upcase, :ma_mon_hoc => l[:ma_mon_hoc].strip.upcase, :ten_mon_hoc => titleize(l[:ten_mon_hoc].strip.downcase) ).first_or_create!      
			
			#Add calendar and assistant
			puts l.inspect
			gv = GiangVien.where(code: l[:ma_giao_vien].strip.upcase).first
			#if lop.id > 606
				calendar = lop.calendars.where(:so_tiet => l[:so_tiet], :so_tuan => l[:so_tuan_hoc], :thu => l[:thu], :tiet_bat_dau => l[:tiet_bat_dau], :tuan_hoc_bat_dau => l[:tuan_hoc_bat_dau], :giang_vien_id => gv.id).first_or_create!
				calendar.update_attributes(phong: (l[:ma_phong_hoc].strip if l.has_key?(:ma_phong_hoc) and l[:ma_phong_hoc].is_a?(String)))
				lop.assistants.where(giang_vien_id: gv.id).first_or_create!
			#end
		end

	end
  end
  
  #31 load lop phan cong va lop mon hoc
  task load_sinh_vien_lop_mon_hoc: :environment do
    tenant = Tenant.last
    Octopus.using(tenant.database) do 
      #LopMonHoc.delete_all
      #ActiveRecord::Base.connection.reset_pk_sequence!('lop_mon_hocs') 
      @client = Savon.client(wsdl: "http://10.1.0.236:8088/HPUWebService.asmx?wsdl")
      response = @client.call(:phan_mon_cua_sinh_vien_theo_ky_hien_tai)         
      res_hash = response.body.to_hash                
      ls = res_hash[:phan_mon_cua_sinh_vien_theo_ky_hien_tai_response][:phan_mon_cua_sinh_vien_theo_ky_hien_tai_result][:diffgram][:document_element]
      ls = ls[:phan_mon_cua_sinh_vien_theo_ky_hien_tai]
      puts "loading... lop mon hoc"
      ls.each_with_index do |l,i|       
        #lop = LopMonHoc.where(:ma_lop => l[:ma_lop_mon_hoc].strip.upcase, :ma_mon_hoc => l[:ma_mon_hoc].strip.upcase, :ten_mon_hoc => titleize(l[:ten_mon_hoc].strip.downcase) ).first_or_create!      
	lop = LopMonHoc.where(:ma_lop => l[:ma_lop_mon_hoc].strip.upcase, :ma_mon_hoc => l[:ma_mon_hoc].strip.upcase, :ten_mon_hoc => titleize(l[:ten_mon_hoc].strip.downcase) ).first
        if lop			
		mon = MonHoc.where(:ma_mon_hoc => l[:ma_mon_hoc].strip.upcase).first_or_create!
	        mon.ten_mon_hoc = titleize(l[:ten_mon_hoc].strip.downcase)
	        sv = SinhVien.where(code: (l[:ma_sinh_vien].strip.upcase if l[:ma_sinh_vien]) ).first      
	        if sv #and lop.id > 606
	          lmhsv = lop.enrollments.where(sinh_vien_id: sv.id).first_or_create!
	        else
	          puts "#{l[:ma_sinh_vien]}"
	        end
	end
      end
    end
  end
  #4 Them thoi khoa bieu va giang vien chinh
  task load_calendar: :environment do
    tenant = Tenant.last
    Octopus.using(tenant.database) do 
    #LichTrinhGiangDay.delete_all
    #ActiveRecord::Base.connection.reset_pk_sequence!('lich_trinh_giang_days') 
    #Calendar.delete_all
    #ActiveRecord::Base.connection.reset_pk_sequence!('calendars') 
      @client = Savon.client(wsdl: "http://10.1.0.236:8088/HPUWebService.asmx?wsdl")
      response = @client.call(:tkb_theo_giai_doan)         
      res_hash = response.body.to_hash                
      ls = res_hash[:tkb_theo_giai_doan_response][:tkb_theo_giai_doan_result][:diffgram][:document_element]
      ls = ls[:tkb_theo_giai_doan]
      
      ls.each_with_index do |l,i| 
        puts l.inspect
        gv = GiangVien.where(code: l[:ma_giao_vien].strip.upcase).first
        lop = LopMonHoc.where(ma_lop: l[:ma_lop].strip.upcase, ma_mon_hoc: l[:ma_mon_hoc].strip.upcase).first
        if lop # and lop.id > 606
          calendar = lop.calendars.where(:so_tiet => l[:so_tiet], :so_tuan => l[:so_tuan_hoc], :thu => l[:thu], :tiet_bat_dau => l[:tiet_bat_dau], :tuan_hoc_bat_dau => l[:tuan_hoc_bat_dau], :giang_vien_id => gv.id).first_or_create!
          calendar.update_attributes(phong: (l[:ma_phong_hoc].strip if l.has_key?(:ma_phong_hoc) and l[:ma_phong_hoc].is_a?(String)))
          lop.assistants.where(giang_vien_id: gv.id).first_or_create!
        end
      end
    end
  end
  # 5: start lop  
  task :start_lop => :environment do
    tenant = Tenant.last
    Octopus.using(tenant.database) do  
      LopMonHoc.all.each do |lop|
        #if lop.id > 606
			lop.start!
			lop.generate_calendars
		#end
      end
    end
  end  
  
  def titleize(str)
    return "" unless str
    str.split(" ").map(&:capitalize).join(" ").gsub("Ii","II")
  end
  def convert(str)     
    return "" unless str 
    return str.chars.map {|w| cv(w)}.join 
  end
  def cv(word)
    case word
    when 'À'
      return 'az1'
    when 'Á'
      return 'az2'
    when 'Ả'
      return 'az3'
    when 'Ã'
      return 'az4'
    when 'Ạ'
      return 'az5'
    when 'Ă'
      return 'az6'
    when 'Ằ'
      return 'az7'
    when 'Ắ'
      return 'az8'
    when 'Ẳ'
      return 'az9'
    when 'Ẵ'
      return 'az91'
    when 'Ặ'
      return 'az92'
    when 'Â'
      return 'az93'
    when 'Ầ'
      return 'az94'
    when 'Ấ'
      return 'az95'
    when 'Ẩ'
      return 'az96'
    when 'Ẫ'
      return 'az97'
    when 'Ậ'
      return 'az98'
    when 'Đ'
      return 'dz'
    when 'È'
      return 'ez'
    when 'É'
      return 'ez2'
    when 'Ẻ'
      return 'ez3'
    when 'Ẽ'
      return 'ez4'
    when 'Ẹ'
      return 'ez5'
    when 'Ê'
      return 'ez6'
    when 'Ề'
      return 'ez7'
    when 'Ế'
      return 'ez8'
    when 'Ể'
      return 'ez9'
    when 'Ễ'
      return 'ez91'
    when 'Ệ'
      return 'ez92'
    when 'Ì'
      return 'iz'
    when 'Í'
      return 'iz2'
    when 'Ỉ'
      return 'iz3'
    when 'Ĩ'
      return 'iz4'
    when 'Ị'
      return 'iz5'
    when 'Ò'
      return 'oz'
    when 'Ó'
      return 'oz2'
    when 'Ỏ'
      return 'oz3'
    when 'Õ'
      return 'oz4'
    when 'Ọ'
      return 'oz5'
    when 'Ô'
      return 'oz6'
    when 'Ồ'
      return 'oz7'
    when 'Ố'
      return 'oz8'
    when 'Ổ'
      return 'oz9'
    when 'Ỗ'
      return 'oz91'
    when 'Ộ'
      return 'oz92'
    when 'Ơ'
      return 'oz93'
    when 'Ờ'
      return 'oz94'
    when 'Ớ'
      return 'oz95'
    when 'Ở'
      return 'oz96'
    when 'Ỡ'
      return 'oz97'
    when 'Ợ'
      return 'oz98'
    when 'Ù'
      return 'uz'
    when 'Ú'
      return 'uz2'
    when 'Ủ'
      return 'uz3'
    when 'Ũ'
      return 'uz4'
    when 'Ụ'
      return 'uz5'
    when 'Ư'
      return 'uz6'
    when 'Ừ'
      return 'uz7'
    when 'Ứ'
      return 'uz8'
    when 'Ử'
      return 'uz9'
    when 'Ữ'
      return 'uz91'
    when 'Ự'
      return 'uz92'
    when 'Ỳ'
      return 'yz'
    when 'Ý'
      return 'yz2'
    when 'Ỷ'
      return 'yz3'
    when 'Ỹ'
      return 'yz4'
    when 'Ỵ'
      return 'yz5'
    when 'à'
      return 'az1'
    when 'á'
      return 'az2'
    when 'ả'
      return 'az3'
    when 'ã'
      return 'az4'
    when 'ạ'
      return 'az5'
    when 'ă'
      return 'az6'
    when 'ằ'
      return 'az7'
    when 'ắ'
      return 'az8'
    when 'ẳ'
      return 'az9'
    when 'ẵ'
      return 'az91'
    when 'ặ'
      return 'az92'
    when 'â'
      return 'az93'
    when 'ầ'
      return 'az94'
    when 'ấ'
      return 'az95'
    when 'ẩ'
      return 'az96'
    when 'ẫ'
      return 'az97'
    when 'ậ'
      return 'az98'
    when 'đ'
      return 'dz'
    when 'è'
      return 'ez'
    when 'é'
      return 'ez2'
    when 'ẻ'
      return 'ez3'
    when 'ẽ'
      return 'ez4'
    when 'ẹ'
      return 'ez5'
    when 'ê'
      return 'ez6'
    when 'ề'
      return 'ez7'
    when 'ế'
      return 'ez8'
    when 'ể'
      return 'ez9'
    when 'ễ'
      return 'ez91'
    when 'ệ'
      return 'ez92'
    when 'ì'
      return 'iz'
    when 'í'
      return 'iz2'
    when 'ỉ'
      return 'iz3'
    when 'ĩ'
      return 'iz4'
    when 'ị'
      return 'iz5'
    when 'ò'
      return 'oz'
    when 'ó'
      return 'oz2'
    when 'ỏ'
      return 'oz3'
    when 'õ'
      return 'oz4'
    when 'ọ'
      return 'oz5'
    when 'ô'
      return 'oz6'
    when 'ồ'
      return 'oz7'
    when 'ố'
      return 'oz8'
    when 'ổ'
      return 'oz9'
    when 'ỗ'
      return 'oz91'
    when 'ộ'
      return 'oz92'
    when 'ơ'
      return 'oz93'
    when 'ờ'
      return 'oz94'
    when 'ớ'
      return 'oz95'
    when 'ở'
      return 'oz96'
    when 'ỡ'
      return 'oz97'
    when 'ợ'
      return 'oz98'
    when 'ù'
      return 'uz'
    when 'ú'
      return 'uz2'
    when 'ủ'
      return 'uz3'
    when 'ũ'
      return 'uz4'
    when 'ụ'
      return 'uz5'
    when 'ư'
      return 'uz6'
    when 'ừ'
      return 'uz7'
    when 'ứ'
      return 'uz8'
    when 'ử'
      return 'uz9'
    when 'ữ'
      return 'uz91'
    when 'ự'
      return 'uz92'
    when 'ỳ'
      return 'yz'
    when 'ý'
      return 'yz2'
    when 'ỷ'
      return 'yz3'
    when 'ỹ'
      return 'yz4'
    when 'ỵ'
      return 'yz5'
    else
      return word.downcase    
    end
  end

end