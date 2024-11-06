"use client";
import { ReactNode } from "react";

import { WagmiProvider } from "@/app/core/hooks/WagmiProvider/WagmiProvider";
import { TokenBalancesProvider } from "@/app/core/context/TokenBalanceContext/TokenBalanceContext";
import { ConnectedUserProvider } from "@/app/core/hooks/useConnectedUser";
import { TransactionsProvider } from "@/app/core/context/TransactionsContext/TransactionsContext";
import { ToastProvider } from "@/app/core/context/ToastContext/ToastContext";
import Header from "../components/Header/Header";
import { Footer } from "../components/Footer/Footer";
import { Features } from "@/app/layout";
import { useSentry } from "./useSentry";
import { Toaster } from "../components/Toaster/Toaster";
import { ModalProvider } from "../context/ModalContext";
import { ModalPresenter } from "../components/Modal/ModalPresenter";
import { QueryClient, QueryClientProvider } from "react-query";

const queryClient = new QueryClient();

export function AppProvider({
  children,
  features,
}: {
  children: ReactNode;
  features: Features;
}) {
  useSentry();

  return (
    <WagmiProvider>
      <ConnectedUserProvider features={features}>
        <QueryClientProvider client={queryClient}>
          <TokenBalancesProvider>
            <ToastProvider>
              <TransactionsProvider>
                <ModalProvider>
                  <Layout>{children}</Layout>
                </ModalProvider>
              </TransactionsProvider>
            </ToastProvider>
          </TokenBalancesProvider>
        </QueryClientProvider>
      </ConnectedUserProvider>
    </WagmiProvider>
  );
}

function Layout({ children }: { children: ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />
      <main className="grow relative">
        <ModalPresenter />
        <Toaster />
        {children}
      </main>
      <Footer />
    </div>
  );
}
