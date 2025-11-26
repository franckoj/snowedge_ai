import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  weight: ["400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: "Supertonic TTS - Lightning Fast Text-to-Speech",
  description: "Experience lightning-fast, on-device text-to-speech powered by Supertonic. Generate natural-sounding speech with multiple voice styles.",
  keywords: ["text-to-speech", "TTS", "Supertonic", "voice synthesis", "ONNX", "AI"],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  );
}
