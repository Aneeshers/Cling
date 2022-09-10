class alpaca_account {
  //Contact
  String email_address;
  String phone_number;
  String street_address; // needs to be of type array
  String city;
  String state;
  String postal_code;

  //Identity
  String given_name;
  String family_name;
  String date_of_birth; // MM/DD/YYYY HH:mm:ss
  String country_of_tax_residency;
  String funding_source;

  //Disclosures
  bool is_control_person;
  bool is_affiliated_exchange_or_finra;
  bool is_politically_exposed;
  bool immediate_family_exposed;

  alpaca_account(
      this.email_address, this.phone_number, this.street_address, this.city, this.state, this.postal_code,
      this.given_name, this.family_name, this.date_of_birth, this.country_of_tax_residency, this.funding_source,
      this.is_control_person, this.is_affiliated_exchange_or_finra, this.is_politically_exposed, this.immediate_family_exposed
      );
}