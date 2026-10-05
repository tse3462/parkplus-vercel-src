import * as React from "react";
import { cn } from "@/lib/utils";

const Input = React.forwardRef<HTMLInputElement, React.ComponentProps<"input">>(
  ({ className, type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          "flex h-11 w-full rounded-md bg-raised px-3 text-sm text-fg shadow-[0_0_0_1px_rgba(232,228,217,0.12)] transition-[box-shadow] duration-150 placeholder:text-faint focus-visible:outline-none focus-visible:shadow-[0_0_0_2px_rgba(232,228,217,0.45)] disabled:cursor-not-allowed disabled:opacity-50",
          className,
        )}
        ref={ref}
        {...props}
      />
    );
  },
);
Input.displayName = "Input";

export { Input };
