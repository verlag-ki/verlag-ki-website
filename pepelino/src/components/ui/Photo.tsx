import Image from "next/image";
import { getMedia } from "@/content/media";
import { asset } from "@/lib/assets";

type Props = {
  media: string;
  sizes: string;
  className?: string;
  priority?: boolean;
  /** Bild füllt den (relativ positionierten) Elternrahmen. */
  fill?: boolean;
  alt?: string;
};

/** Einheitlicher Bild-Baustein: liest Maße, Alt-Text und Fokuspunkt aus dem MediaAsset. */
export function Photo({ media: key, sizes, className = "", priority, fill = true, alt }: Props) {
  const m = getMedia(key);
  const style = m.objectPosition ? { objectPosition: m.objectPosition } : undefined;
  if (fill) {
    return (
      <Image
        src={asset(m.src)}
        alt={alt ?? m.alt}
        fill
        sizes={sizes}
        priority={priority}
        className={`object-cover ${className}`}
        style={style}
        data-rights={m.rightsStatus}
      />
    );
  }
  return (
    <Image
      src={asset(m.src)}
      alt={alt ?? m.alt}
      width={m.width}
      height={m.height}
      sizes={sizes}
      priority={priority}
      className={className}
      style={style}
      data-rights={m.rightsStatus}
    />
  );
}
