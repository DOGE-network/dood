# tables

## overview
- holds source data for cali-doge and other transparency tools to utilize
- raw holds spreadsheets and lists from public sources that need to be modified for use
- sources is where California DOGE and other sites can pull from at build to include for tooling

## source file formats

### corporate_entity_metadata.tsv

	•	EIN: Employer Identification Number (unique tax ID for the entity)
	•	CorpName: Legal name of the corporation
	•	IncorpLocation: Jurisdiction where the entity is incorporated (e.g., state, country)
	•	IncorpDate: Date of incorporation (format: YYYY-MM-DD)
	•	EntityType: Type of entity (e.g., Corporation, LLC, Partnership)
	•	Status: Current status (e.g., Active, Inactive, Dissolved)
	•	BusinessAddress: Primary business address
	•	MailingAddress: Mailing address (if different from business address)
	•	RegisteredAgent: Name/contact of registered agent
	•	Phone: Main contact phone number
	•	Email: Main contact email address
	•	Website: Company website URL
	•	NAICSCode: North American Industry Classification System code (or similar industry code)
	•	FEIN: Federal Employer Identification Number (if different from EIN or for international entities)
	•	ParentEntity: Name or ID of parent company (if applicable)
	•	Notes: Free-text notes or comments