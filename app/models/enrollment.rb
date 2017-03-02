class Enrollment < ActiveRecord::Base

  default_scope {includes(:sinh_vien).order('sinh_viens.encoded_position')}
# attr_accessible :sinh_vien_id, :bosung, :tong_tiet_vang
# belongs_to :lop_mon_hoc, :conditions => ['lop_mon_hocs.state != ?','removed']
  belongs_to :lop_mon_hoc
  belongs_to :sinh_vien
  has_many :lich_trinh_giang_days, :through => :lop_mon_hoc
  #validates :lop_mon_hoc, :sinh_vien, :presence => true
  has_many :assignment_groups, -> {uniq},  :through => :lop_mon_hoc
  has_many :group_submissions, :dependent => :destroy
  has_many :assignments, -> {uniq}, :through => :lop_mon_hoc
  has_many :attendances, :through => :sinh_vien
  has_many :submissions, :dependent => :destroy
  before_destroy :delete_attendances

  def tong_vang  
    attendances.where(lich_trinh_giang_day_id: lich_trinh_giang_days.not_tuhoc.map(&:id)).not_idle.where('phep is NULL or phep=false').sum(:so_tiet_vang).to_i
  end
  def so_tiet_thua
    attendances.idle.inject(0) {|res, at| (res || 0) + (at.lich_trinh_giang_day.so_tiet || 0) if at.lich_trinh_giang_day.ltype != "tuhoc"}
  end
  def diemqt
    #group_submissions.sum(:grade).round(0).to_i
    if diem_chuyen_can == 0
       0
    else
       group_submissions.sum(:grade).round(0).to_i
    end
  end
  def diem_chuyen_can
    thv = tinhhinhvang.to_i
    #thv = (((tong_vang * 100.0)/khoi_luong_du_kien).round(2)).round(0)
    case thv
    when 0
      10
    when 0.01..7
      7.5
  when 7.01..14
      5
    when 14.01..20
      2.5
    else
      0
    end     
  end
 def tinhhinhvang
    tmp = lop_mon_hoc.khoi_luong_du_kien.to_i || 0
	  tmp = 10000 if tmp == 0
    (((tong_vang || 0) * 100.0) / tmp).to_f.round(2)
  end

private
  def delete_attendances
    Attendance.delete_all(id: attendances.map(&:id))
  end
end