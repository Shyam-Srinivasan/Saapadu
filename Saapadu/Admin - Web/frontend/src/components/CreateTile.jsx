import React from "react";
import "./Tile.css";

export const CreateTile = ({ openCreate , type}) => {
  const handleActivate = () => {
    if (typeof openCreate === "function") {
      openCreate();
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      handleActivate();
    }
  };

  return (
    <div
      className="tile-card"
      style={{ cursor: "pointer" }}
      onClick={handleActivate}
      onKeyDown={handleKeyDown}
      role="button"
      tabIndex={0}
      aria-label="Create new shop"
    >
      <div className="tile-card__shine" />
      <div className="tile-card__glow" />
      <div className="tile-card__content justify-content-center">
          <div className="shotile-card__button text-center" aria-hidden="true">
            <svg height={25} width={25} viewBox="0 0 24 24" aria-hidden="true">
              <path
                strokeWidth={2}
                stroke="currentColor"
                d="M4 12H20M12 4V20"
                fill="currentColor"
              />
            </svg>
          </div>
          <div className="tile-card__badge">ADD</div>
          <div className="tile-card__text">
              <p className="tile-card__title text-center">Create {type === "shop" ? "Shop" : type === "category" ? "Category" : "Item"}</p>
          </div>

      </div>
    </div>
  );
};