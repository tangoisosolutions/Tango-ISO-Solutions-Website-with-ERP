# Tango ISO Solutions: website + ERP
Static site (no build). Public pages are plain HTML (SEO friendly); the ERP (`login.html`, `erp.html`) uses Supabase for login and data.

## Files
- `index.html`, `about.html`, `services.html`, `iso-*-consultancy.html`, `ims-iso-consultancy.html`, `iso-consultancy.html`, `specialized-iso-documents.html`, `zed-certification-consultancy.html`, `customer-audit-support.html`, `policies-legal.html`, `inquiry.html`, `career.html`
- `documents/*.pdf` policy and legal downloads
- `login.html`, `erp.html`, `assets/js/erp.js`, `assets/css/erp.css` ERP
- `assets/js/site.js` menu + forms; `supabase-setup.sql` database; `sitemap.xml`, `robots.txt`

## Setup
1. Supabase > SQL Editor: run `supabase-setup.sql`.
2. Supabase > Authentication > Sign In / Providers > Email: turn **Confirm email OFF**.
3. Authentication > Users > Add user (your email + password, Auto Confirm). Then run the last (commented) `update profiles ...` line to make yourself admin.
4. Edit the `CO` block at the top of `assets/js/erp.js` (address, GSTIN, PAN, bank details) for printed quotations and invoices.
5. Deploy to Netlify as before.

## Roles
Admin: everything, can delete records and add or deactivate employees. Employee: everything except deleting and employee management (enforced in the database).
