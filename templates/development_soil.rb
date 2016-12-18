class DevelopmentSoil
  def self.seed(*pieces)
    soil = new

    if pieces.any?
      pieces.each { |piece| soil.public_send("seed_#{piece}") }
    else
      soil.seed_all
    end
  end

  include FactoryGirl::Syntax::Methods

  def seed_all
    seed_records
  end

  def seed_records
    announce "Seeding records"

    Model.delete_all

    records = [create(:record)]
    report_seeds records, :name
  end

  private

  def announce(message)
    puts "\e[34m### #{message}\e[0m"
  end

  def report_seed(record, *attribute_names, &block)
    inspected_attributes = inspected_attributes_for_seed(
      record,
      attribute_names,
      &block
    )

    puts "Created #{record.class}: (#{inspected_attributes})"
  end

  def report_seeds(records, *attribute_names)
    records.each do |record|
      report_seed(record, *attribute_names)
    end
  end

  def inspected_attributes_for_seed(record, attribute_names)
    attributes =
      if block_given?
        yield
      else
        attributes_for_seed(record, attribute_names)
      end

    key_value_pairs = attributes.map do |key, value|
      "#{key}: #{value.inspect}"
    end

    key_value_pairs.join(", ")
  end

  def attributes_for_seed(record, attribute_names)
    attribute_names.reduce({}) do |hash, name|
      hash.merge(name => record.public_send(name))
    end
  end
end
