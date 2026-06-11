import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createUser from '@salesforce/apex/UserProfileController.createUser';

export default class UserProfileForm extends LightningElement {
    fullName = '';
    email = '';
    leetcode = '';
    codechef = '';
    avatarUrl = '';
    reminderTime = '20:00';
    summaryTime = '08:00';
    motivationEmails = true;
    reminderEnabled = true;

    handleName(event) { this.fullName = event.target.value; }
    handleEmail(event) { this.email = event.target.value; }
    handleLeetCode(event) { this.leetcode = event.target.value; }
    handleCodeChef(event) { this.codechef = event.target.value; }

    handleAvatarUrl(event) {
        this.avatarUrl = event.target.value;
        const el = this.template.querySelector('.avatarPreview');
        if (el) {
            el.style.setProperty('--avatar-url', `url('${this.avatarUrl}')`);
        }
    }

    handleReminderTime(event) { this.reminderTime = event.target.value; }
    handleSummaryTime(event) { this.summaryTime = event.target.value; }
    handleMotivation(event) { this.motivationEmails = event.target.checked; }

    async saveProfile() {
        if (!this.fullName?.trim() || !this.email?.trim()) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Required Fields',
                    message: 'Please enter your name and email',
                    variant: 'warning'
                })
            );
            return;
        }

        try {
            await createUser({
                fullName: this.fullName,
                email: this.email,
                leetCodeUsername: this.leetcode,
                codeChefUsername: this.codechef,
                avatarUrl: this.avatarUrl,
                reminderTime: this.reminderTime,
                morningSummaryTime: this.summaryTime,
                reminderEnabled: this.reminderEnabled,
                motivationEmails: this.motivationEmails
            });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Profile Created',
                    message: '🚀 Welcome to CodePulse AI',
                    variant: 'success'
                })
            );
        } catch (error) {
            console.error(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error?.body?.message || 'Error saving profile',
                    variant: 'error'
                })
            );
        }
    }
}
