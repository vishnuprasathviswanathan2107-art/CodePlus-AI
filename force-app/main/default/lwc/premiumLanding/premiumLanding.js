import { LightningElement } from 'lwc';

const VIDEO_URL =
    'https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260328_091828_e240eb17-6edc-4129-ad9d-98678e3fd238.mp4';

const NAV_LABELS = ['Start', 'Story', 'Rates', 'Benefits', 'FAQ'];

export default class PremiumLanding extends LightningElement {
    videoUrl = VIDEO_URL;
    mobileMenuOpen = false;

    navItems = NAV_LABELS.map((label, index) => ({
        id: `nav-${index}`,
        label,
        href: `#${label.toLowerCase()}`
    }));

    get menuAriaLabel() {
        return this.mobileMenuOpen ? 'Close menu' : 'Open menu';
    }

    toggleMobileMenu() {
        this.mobileMenuOpen = !this.mobileMenuOpen;
    }

    closeMobileMenu() {
        this.mobileMenuOpen = false;
    }
}
