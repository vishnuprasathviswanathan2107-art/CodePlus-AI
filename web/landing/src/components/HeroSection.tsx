import { useState } from 'react';
import { Menu, X } from 'lucide-react';

const VIDEO_URL =
  'https://d8j0ntlcm91z4.cloudfront.net/user_38xzZboKViGWJOttwIXH07lWA1P/hf_20260328_091828_e240eb17-6edc-4129-ad9d-98678e3fd238.mp4';

const NAV_ITEMS = ['Start', 'Story', 'Rates', 'Benefits', 'FAQ'] as const;

export default function HeroSection() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const toggleMobileMenu = () => setMobileMenuOpen((open) => !open);

  const closeMobileMenu = () => setMobileMenuOpen(false);

  return (
    <section className="relative h-screen overflow-hidden">
      <video
        className="absolute inset-0 h-full w-full object-cover"
        autoPlay
        muted
        loop
        playsInline
      >
        <source src={VIDEO_URL} type="video/mp4" />
      </video>

      <div className="relative flex h-full flex-col">
        <header className="relative z-20">
          <div className="mx-auto max-w-7xl px-8 py-6">
            <nav className="flex items-center justify-between">
              <a
                href="#"
                className="text-2xl font-semibold text-gray-900 transition-colors"
              >
                SkyElite
              </a>

              <ul className="hidden items-center gap-8 md:flex">
                {NAV_ITEMS.map((item) => (
                  <li key={item}>
                    <a
                      href={`#${item.toLowerCase()}`}
                      className="text-gray-900 transition-colors hover:text-gray-700"
                    >
                      {item}
                    </a>
                  </li>
                ))}
              </ul>

              <button
                type="button"
                className="text-gray-900 transition-colors hover:text-gray-700 md:hidden"
                onClick={toggleMobileMenu}
                aria-label={mobileMenuOpen ? 'Close menu' : 'Open menu'}
                aria-expanded={mobileMenuOpen}
              >
                {mobileMenuOpen ? (
                  <X className="h-6 w-6" />
                ) : (
                  <Menu className="h-6 w-6" />
                )}
              </button>
            </nav>

            {mobileMenuOpen && (
              <div className="mt-4 rounded-2xl border border-white/40 bg-white/95 p-4 shadow-lg backdrop-blur-md md:hidden">
                <ul className="flex flex-col gap-3">
                  {NAV_ITEMS.map((item) => (
                    <li key={item}>
                      <a
                        href={`#${item.toLowerCase()}`}
                        className="block rounded-lg px-3 py-2 text-gray-900 transition-colors hover:bg-gray-100 hover:text-gray-700"
                        onClick={closeMobileMenu}
                      >
                        {item}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        </header>

        <main className="flex flex-1 items-center justify-center">
          <div className="-mt-80 text-center">
            <p className="mb-4 text-sm font-semibold tracking-wider text-gray-600 uppercase">
              Private Jets
            </p>

            <h1 className="leading-none tracking-tighter">
              <span className="block text-6xl font-normal text-gray-500 md:text-7xl lg:text-8xl">
                Premium.
              </span>
              <span className="-mt-[12px] block text-6xl font-normal text-[#202A36] md:text-7xl lg:text-8xl">
                Accessible.
              </span>
            </h1>

            <p className="mx-auto mt-6 mb-6 max-w-2xl text-lg text-gray-600 md:text-xl">
              Your dedication deserves recognition.
            </p>

            <div className="flex flex-wrap items-center justify-center gap-4">
              <button
                type="button"
                className="rounded-full bg-gray-300 px-4 py-2 font-medium text-gray-800 transition-colors hover:bg-gray-400"
              >
                Discover
              </button>
              <button
                type="button"
                className="rounded-full bg-[#202A36] px-4 py-2 font-medium text-white transition-colors hover:bg-[#1a2229]"
              >
                Book Now
              </button>
            </div>
          </div>
        </main>
      </div>
    </section>
  );
}
