class A
  def initialize(collector = [])
    @collector = collector
  end

  def call
    A.new(@collector + ['thing'])
  end
end


a = A.new(['lala', 'lolo'])

old_a = a

a = a.call.call.call
p a


q = Campaign.where(url_key: '123')

sorted_q = q.sort

def active
  where(is_active: true)
end

c = Campaign.where(lala: 123)

active_c = c.active

c


function Relation(state) {
  this.state = state
}

Relation.prototype.where = function(query) {
  return new Campaign(_.extend({}, this.state, query)
}
