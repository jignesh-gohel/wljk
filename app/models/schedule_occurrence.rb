class ScheduleOccurrence < ActiveRecord::Base
  attr_accessible :next_occurrence, :occurrence_status, :scheduled_entity_id

  belongs_to :mail_template

  scope :due, where(occurrence_status: 'due')

  # http://stackoverflow.com/questions/4500629/use-arel-for-a-nested-set-join-query-and-convert-to-activerecordrelation
  scope :due_before, lambda { |datetime| due.where(self.arel_table[:next_occurrence].lteq(datetime)) }
end
