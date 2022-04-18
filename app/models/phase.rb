class Phase < ApplicationRecord
  belongs_to :company
  belongs_to :project
  belongs_to :assigned_to, class_name: "User"
  has_many :notes, as: :owner, dependent: :destroy
  has_many :steps, dependent: :destroy
  has_rich_text :details

  validates :start_date, :end_date, :name, presence: true

  def delayed?
    Time.zone.today >= end_date && !completed
  end

  def on_time_status
    if completed
      "Complete"
    else
      Time.zone.today < end_date ? "On-Time" : "Delayed"
    end
  end
end