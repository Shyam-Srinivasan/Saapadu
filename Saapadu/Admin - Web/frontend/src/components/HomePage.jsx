import React from "react";
import {StatsTile} from "./StatsTile";
import {Container} from "react-bootstrap";
import {RecentOrdersTable} from "./RecentOrdersTable";

export const HomePage = () => {
    return (
        <Container fluid className="bg-white">
            <div className="stats-row bg-white">
                <StatsTile name="Total Orders"/>
                <StatsTile name="Pending Orders"/>
                <StatsTile name="Completed Orders"/>
                <StatsTile name="Total Revenue"/>
            </div>

            <div className="recent-orders" style={{margin: "20px 20px"}}>
                <h3 className="fs-5 text-start">Recent Orders</h3>
                <div className="recent-order-table">
                    <RecentOrdersTable/>
                </div>
            </div>
        </Container>

    );
};
